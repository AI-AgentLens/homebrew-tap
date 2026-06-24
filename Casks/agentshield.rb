cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1431"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1431/agentshield_0.2.1431_darwin_amd64.tar.gz"
      sha256 "f91b9b70296415f1371f3e199598e8b96fadffe3d20e7059a9260fc387a4db51"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1431/agentshield_0.2.1431_darwin_arm64.tar.gz"
      sha256 "64dd47a579651ddc5bdd03576583131e219da351b0925ea996f30264fb69ab7f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1431/agentshield_0.2.1431_linux_amd64.tar.gz"
      sha256 "cc57b081ac8f3da54dfe9676636edfd20ce84672995d2185621881ec19541b44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1431/agentshield_0.2.1431_linux_arm64.tar.gz"
      sha256 "9d4609562a2b995b6ae4c0f7c4c59bfbcc3facec7ed532e11fa18408f7c4d908"
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
