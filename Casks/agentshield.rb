cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2227"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2227/agentshield_0.2.2227_darwin_amd64.tar.gz"
      sha256 "8e41c0c0aed53f53691e332d5843a8e51faf1a38bf30ad891ed7af187fd73f75"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2227/agentshield_0.2.2227_darwin_arm64.tar.gz"
      sha256 "065edb6d10d2a6f6cefb469d6022ea0975d7436834390bfdbb2bdb7c74474b03"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2227/agentshield_0.2.2227_linux_amd64.tar.gz"
      sha256 "c2c665e3063e8ff8393bd40e715c3a11206b6dda97bc4a62161a4795357c422d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2227/agentshield_0.2.2227_linux_arm64.tar.gz"
      sha256 "863c3849908997c36685a4376fb1c297df644406e0f9777b18d59abe9e9e0717"
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
