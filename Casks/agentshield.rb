cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2157"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2157/agentshield_0.2.2157_darwin_amd64.tar.gz"
      sha256 "2439c3d046562054deee085ca3fbff862df2c81d38720fdf8874e932595292aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2157/agentshield_0.2.2157_darwin_arm64.tar.gz"
      sha256 "6d7aa397d54458ba8bf9e71e337945a6fd4e2f3a691e139501758b9d2db729e1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2157/agentshield_0.2.2157_linux_amd64.tar.gz"
      sha256 "acaf5b91e0a7e41d0c0f9730f218e476d04b7a72b955d8258dfab76ab0256f84"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2157/agentshield_0.2.2157_linux_arm64.tar.gz"
      sha256 "2eea2df6f83e409bfda5498fe3a35a3b7e378dba9350c13bb19a85d30e4cd9d5"
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
