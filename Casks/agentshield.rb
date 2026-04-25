cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.734"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.734/agentshield_0.2.734_darwin_amd64.tar.gz"
      sha256 "a060865f1b7f49140d0e5e35d0d05f2b2ac2ec865687efbde0fe6e531722e58e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.734/agentshield_0.2.734_darwin_arm64.tar.gz"
      sha256 "ac27a98ee62fdde36b8ab0dbf5529c3eeb1e17ec71fbf4d14ff17cbc64c7a07e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.734/agentshield_0.2.734_linux_amd64.tar.gz"
      sha256 "6aa0bd75c6f35b71b07eb17fa2281f8d6df665e72943be6563ae66e69136a2b5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.734/agentshield_0.2.734_linux_arm64.tar.gz"
      sha256 "2619c242bc173a22cb0ec24043e4953f7ccc575d468a38e8482c4883121b5d91"
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
