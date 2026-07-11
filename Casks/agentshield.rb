cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1614"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1614/agentshield_0.2.1614_darwin_amd64.tar.gz"
      sha256 "b50723b1acc96e7729aba9311b78252f2d6aae1fd7998db3114a4585d2d02069"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1614/agentshield_0.2.1614_darwin_arm64.tar.gz"
      sha256 "d269ed485ec97e680c3837745344f41b52c1560b0c225cf3df873340b1ee9746"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1614/agentshield_0.2.1614_linux_amd64.tar.gz"
      sha256 "56e39bd699c027ef9b8a9e21fa337bb8eb33137ffcd7a8b49c248d7c208bbe3e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1614/agentshield_0.2.1614_linux_arm64.tar.gz"
      sha256 "b139ef5e32b6010acd6163bd263cb6c09b032f5d15d5acdf45434062522233ed"
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
