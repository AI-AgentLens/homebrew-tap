cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.775"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.775/agentshield_0.2.775_darwin_amd64.tar.gz"
      sha256 "8cbcf2207960efb9f2c86987322adfa07e31ba95cb659c5b14c8cbd3a6ca09cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.775/agentshield_0.2.775_darwin_arm64.tar.gz"
      sha256 "b9ce8d5e7435a802215f4ff87346fcb97775270fb9fc3ed013ad762b02f1a644"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.775/agentshield_0.2.775_linux_amd64.tar.gz"
      sha256 "337333de73f9d7a35be125e49941b22b821688d7cbc463bf6d2cc112589a35db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.775/agentshield_0.2.775_linux_arm64.tar.gz"
      sha256 "16938a98b0f2031db9ee9df4b26d90892609fbfce4c43dc902126a1d971c2bba"
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
