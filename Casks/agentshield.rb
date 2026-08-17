cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1885"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1885/agentshield_0.2.1885_darwin_amd64.tar.gz"
      sha256 "ea54c2e977043eccdd25ce5f3f155f36e3cba14099dbe07311df43dc9e05eb2e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1885/agentshield_0.2.1885_darwin_arm64.tar.gz"
      sha256 "5fa3c1908a917fc85a751cd488f46d7d7fbe168562059be903efb8856331c984"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1885/agentshield_0.2.1885_linux_amd64.tar.gz"
      sha256 "895a23580bb605abcc30ed901eb3cb8991cc5330193d91e93c2fca47a8521b78"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1885/agentshield_0.2.1885_linux_arm64.tar.gz"
      sha256 "306acee7a4a077dad4307466fa13efbf0e292e6482c1c26e8dfe8d6a75e32256"
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
