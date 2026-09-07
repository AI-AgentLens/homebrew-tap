cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2068"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2068/agentshield_0.2.2068_darwin_amd64.tar.gz"
      sha256 "a42f60465da07fc9d9dfd2dda87b60a7958efc8924578d016600f9d6229ae066"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2068/agentshield_0.2.2068_darwin_arm64.tar.gz"
      sha256 "ea5552cce18614734640a68c8089fcece8ac9e83ef963297e90b360c7e4b0de7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2068/agentshield_0.2.2068_linux_amd64.tar.gz"
      sha256 "c7a43987eb7099229b93783996e329b65a5afcdf38795b77747c9314eb3fa3f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2068/agentshield_0.2.2068_linux_arm64.tar.gz"
      sha256 "525ddff0035df89cc1d378ab68fb8b5a922e483c2a87d032e691a5bb00ee7fba"
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
