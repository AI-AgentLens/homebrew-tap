cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1094"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1094/agentshield_0.2.1094_darwin_amd64.tar.gz"
      sha256 "ea3e82cc64cd2d98a058bcc2882b3dda35035158b7c0d973dbebff49c655a3f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1094/agentshield_0.2.1094_darwin_arm64.tar.gz"
      sha256 "abef1bd2d40c813e129d19401615cd2bb0aca763e7cc9d26194ad886427be08e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1094/agentshield_0.2.1094_linux_amd64.tar.gz"
      sha256 "c2b7566c6c292f6ce7808f6ca50153b9b6fddb8d4c1b78e53ebcf21142e9804a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1094/agentshield_0.2.1094_linux_arm64.tar.gz"
      sha256 "5837786e15df1f42e9a565bf4390bb4b9f4cb3f7334b4d507892f1524d54e1f3"
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
