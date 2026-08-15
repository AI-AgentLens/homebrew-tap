cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1860"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1860/agentshield_0.2.1860_darwin_amd64.tar.gz"
      sha256 "5e25337a2f90dcce902a543f3519604e7c2491608f13b72f35b15868ed93e67b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1860/agentshield_0.2.1860_darwin_arm64.tar.gz"
      sha256 "1515b6ab486496fd757dd0dcd6cfe4179b3fd6ec3bedc7b6476198a38e1c2ead"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1860/agentshield_0.2.1860_linux_amd64.tar.gz"
      sha256 "1e1337b16fd0b0a8c98c184571d91a3ef8dab18c8ee3dc461895fff50488325b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1860/agentshield_0.2.1860_linux_arm64.tar.gz"
      sha256 "70d4b1fb08969beace50c09c4425d0fdf4f5edad73dbbdb135b7a75a5784ce9c"
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
