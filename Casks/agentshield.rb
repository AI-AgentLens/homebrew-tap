cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2485"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2485/agentshield_0.2.2485_darwin_amd64.tar.gz"
      sha256 "aae43db1d28ae4fae882853f749c4bda94a4c962a95e86121ccbcb1cd7e34f24"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2485/agentshield_0.2.2485_darwin_arm64.tar.gz"
      sha256 "5f0e59a94363623aa2d3525e9cde817912b8f56172799ac5539cae5daaaaefc8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2485/agentshield_0.2.2485_linux_amd64.tar.gz"
      sha256 "c85be15fe2e1bb6d57597b2fe96d21407a5e42d67719dbb82951c260598624a7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2485/agentshield_0.2.2485_linux_arm64.tar.gz"
      sha256 "e83d0442b495f1453e4d5422acf1d87e68531f9d16a1c0a865734c6783a9e9d9"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
