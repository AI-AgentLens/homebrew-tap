cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1570"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1570/agentshield_0.2.1570_darwin_amd64.tar.gz"
      sha256 "65c96ef9641f65e5894a1e987b2225d711267f7607bd527c1fe42f75491fac3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1570/agentshield_0.2.1570_darwin_arm64.tar.gz"
      sha256 "6db9e0ba094e5ef55992219f0ffbc0a9dad0dc17dfe52950abaf546c0b0f4293"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1570/agentshield_0.2.1570_linux_amd64.tar.gz"
      sha256 "fd412289169cddaa0d436bc595f8562a0540f401dbb765998b97337c29a7c53c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1570/agentshield_0.2.1570_linux_arm64.tar.gz"
      sha256 "8bfcb4f37187c602e26438c93b74011f46ff22879eb42ed3ae788315abdf99be"
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
