cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1087"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1087/agentshield_0.2.1087_darwin_amd64.tar.gz"
      sha256 "5c7ddd0d44091ba11caa1e367ab7b5c7b571c3e9c0ec6bcab93d6fbae076b79b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1087/agentshield_0.2.1087_darwin_arm64.tar.gz"
      sha256 "17436ed6da2facecff99996476bcbb775ad72b5c5274245d6069424ca0ae2800"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1087/agentshield_0.2.1087_linux_amd64.tar.gz"
      sha256 "fcceaa6afa8b4ec3d93bb87239334181475b7ff8319e30e454d6a5e033f98731"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1087/agentshield_0.2.1087_linux_arm64.tar.gz"
      sha256 "37cfeb13828693bde6dbe66f2bb29e92817af00e8c899bce9024f1282f1ac84c"
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
