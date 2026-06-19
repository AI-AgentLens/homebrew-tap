cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1378"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1378/agentshield_0.2.1378_darwin_amd64.tar.gz"
      sha256 "efb8fecac150b5c6a8203215983ee42b308235bb00b10e264c1e12a2c830d785"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1378/agentshield_0.2.1378_darwin_arm64.tar.gz"
      sha256 "45c7a19237a71fc55918a9f1bdf02daf6cd0eeb0c630668ac5b6689285159d1b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1378/agentshield_0.2.1378_linux_amd64.tar.gz"
      sha256 "66ea6007e2a48eb0f3719ae1b5c4df788daa2a4abeb69d111501fd88cd8550fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1378/agentshield_0.2.1378_linux_arm64.tar.gz"
      sha256 "bb986b28dada169238c4cdc9cef8e0dd8433f0a5afe8c19c3d99d6a67e5927b7"
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
