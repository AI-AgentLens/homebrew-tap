cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.919"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.919/agentshield_0.2.919_darwin_amd64.tar.gz"
      sha256 "cb52fbebaafba7b6b4630a0427125ae935087f4ad5e601e7acf5afdc8c1a3d0a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.919/agentshield_0.2.919_darwin_arm64.tar.gz"
      sha256 "53f395aec691b4d38d86562c4708315069e338b169f709af23465e02f9470012"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.919/agentshield_0.2.919_linux_amd64.tar.gz"
      sha256 "a708476c65f48a54cb8b16a3a553acbb08415ef878a9e4b7f2a51b09fdd5d0ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.919/agentshield_0.2.919_linux_arm64.tar.gz"
      sha256 "4ddc7bc6fed5d41501f8816bcbe00474e5de59444b40f4de53da1384320db2cb"
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
