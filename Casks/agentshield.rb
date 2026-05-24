cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1113"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1113/agentshield_0.2.1113_darwin_amd64.tar.gz"
      sha256 "75685addd70058d490eea985abb25965be6cb051a61363f91481bc6b4743b1a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1113/agentshield_0.2.1113_darwin_arm64.tar.gz"
      sha256 "4537015d8b5b9112a5617e6e173f37d8379028ac67aec19a65e780a23c407102"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1113/agentshield_0.2.1113_linux_amd64.tar.gz"
      sha256 "2775fab2de4fc64b2c784de6dc64bd218dec923d72e0708b0669a557f918ed7b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1113/agentshield_0.2.1113_linux_arm64.tar.gz"
      sha256 "2ba4a53a00f6e31ac9d1b1c1eec179307838932fc61b4640b6e5e0e72f5212dd"
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
