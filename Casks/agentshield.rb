cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.202"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.202/agentshield_0.2.202_darwin_amd64.tar.gz"
      sha256 "455106d8bf8aefff336e6077efbe21bc400dde68fdee0a277da0654138a7fdfd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.202/agentshield_0.2.202_darwin_arm64.tar.gz"
      sha256 "eb34e4fa97d302ed7027acaca2f7718c4d67e01aa3a6db1d385f6a4743be1c5c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.202/agentshield_0.2.202_linux_amd64.tar.gz"
      sha256 "8879be58dbdf9e04423ff83c6f096d28d990af88dfb86fec4418fce75248adab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.202/agentshield_0.2.202_linux_arm64.tar.gz"
      sha256 "efb627ef110b53b5125fb716aa2c992fd65705693450d0f936b199bdfe3de7e5"
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
